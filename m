From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 16:19:14 +0300
Message-ID: <5027AD52.7030006@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <20120812105421.GI1421@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:35694 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751825Ab2HLNVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 09:21:00 -0400
In-Reply-To: <20120812105421.GI1421@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 13:54, Michael S. Tsirkin wrote:
> On Wed, Aug 08, 2012 at 08:23:15AM +0300, Or Gerlitz wrote:
>>> So far the things that make sense. Here are some that don't, to me:
>>> - Is a pdf presentation all you have in terms of documentation?
>>>    We are talking communication protocols here - I would expect a
>>>    proper spec, and some effort to standardize, otherwise where's the
>>>    guarantee it won't change in an incompatible way?
>> To be precise, the solution uses 100% IPoIB wire-protocol, so we don't
>> see a need for any spec change / standardization effort.
> Thinking about it some more, the solution is not really 100% local:
> - ARP packets used at migration are visible on the network

The ARP packets on the wire are IPoIB ARP packets -- indeed, when the 
guest moves, the IPoIB
link layer address which was associated with the VIF that used to serve 
this guest on the host
we migrated from, changes to be of a VIF on the host that we migrated to.


> - QPN/LID in MAC are guest visible, and could be exported on the network
>
