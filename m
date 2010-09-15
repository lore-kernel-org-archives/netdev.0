From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 10:46:02 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792B8C815314@shsmsx502.ccr.corp.intel.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
 <4C8F3C77.7010302@redhat.com>
 <1284476719.13351.35.camel@localhost.localdomain>
 <201009141721.13202.arnd@arndb.de> <20100914152231.GA13105@redhat.com>
 <1284480025.13351.49.camel@localhost.localdomain>
 <20100914162952.GB13560@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100914162952.GB13560@redhat.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Michael S. Tsirkin [mailto:mst@redhat.com]
>Sent: Wednesday, September 15, 2010 12:30 AM
>To: Shirley Ma
>Cc: Arnd Bergmann; Avi Kivity; Xin, Xiaohui; David Miller; netdev@vger.kernel.org;
>kvm@vger.kernel.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host kernel
>
>On Tue, Sep 14, 2010 at 09:00:25AM -0700, Shirley Ma wrote:
>> On Tue, 2010-09-14 at 17:22 +0200, Michael S. Tsirkin wrote:
>> > I would expect this to hurt performance significantly.
>> > We could do this for asynchronous requests only to avoid the
>> > slowdown.
>>
>> Is kiocb in sendmsg helpful here? It is not used now.
>>
>> Shirley
>
>Precisely. This is what the patch from Xin Xiaohui does.  That code
>already seems to do most of what you are trying to do, right?
>
>The main thing missing seems to be macvtap integration, so that we can fall back
>on data copy if zero copy is unavailable?
>How hard would it be to basically link the mp and macvtap modules
>together to get us this functionality? Anyone?
>
Michael,
Is to support macvtap with zero-copy through mp device the functionality
you mentioned above?
Before Shirley Ma has suggested to move the zero-copy functionality into
tun/tap device or macvtap device. How do you think about that? I suspect
there will be a lot of duplicate code in that three drivers except we can extract
code of zero-copy into kernel APIs and vhost APIs.
Do you think that's worth to do and help current process which is blocked too
long than I expected?

>
>--
>MST
