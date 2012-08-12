From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 17:13:43 +0300
Message-ID: <5027BA17.6010503@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <20120812102240.GG1421@redhat.com> <5027AC88.2020509@mellanox.com> <20120812135544.GB6003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:44159 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752238Ab2HLOOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 10:14:14 -0400
In-Reply-To: <20120812135544.GB6003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 16:55, Michael S. Tsirkin wrote:
> I didn't realize you do ARP snooping. Why? I know you mangle outgoing 
> ARP packets, 

Maybe I wasn't accurate/clear, we do mangle outgoing/incoming ARP 
packets, from/to Ethernet ARPs
to/from IPoIB ARPs.


> this will go away if you maintain a mapping in SM accessible to all 
> guests. 

guests don't interact with IB, I assume you referred to dom0 code, eIPoIB or
another driver in the host. But what mapping exactly? and remember that
this code (VM through eipoib) can talk to any IPoIB element on the 
fabric, native,
virtualized,  HW/SW gateways, etc etc.

Or.
