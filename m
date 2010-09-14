From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 10:02:25 -0700
Message-ID: <1284483745.13351.71.camel@localhost.localdomain>
References: <1284410580.13351.10.camel@localhost.localdomain>
	 <4C8F3C77.7010302@redhat.com>
	 <1284476719.13351.35.camel@localhost.localdomain>
	 <201009141721.13202.arnd@arndb.de> <20100914152231.GA13105@redhat.com>
	 <1284480025.13351.49.camel@localhost.localdomain>
	 <20100914162952.GB13560@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100914162952.GB13560@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-09-14 at 18:29 +0200, Michael S. Tsirkin wrote:
> Precisely. This is what the patch from Xin Xiaohui does.  That code
> already seems to do most of what you are trying to do, right?

I thought host pins guest kernel buffer pages was good enough for TX
thought I didn't look up xiaohui's vhost asycn io patch in details.

What's the performance data Xiaohui got from using kiocb? I haven't seen
any performance number from him yet.

> The main thing missing seems to be macvtap integration, so that we can
> fall back
> on data copy if zero copy is unavailable?
> How hard would it be to basically link the mp and macvtap modules
> together to get us this functionality? Anyone? 

The simple integration is using macvtap + xiaohui's vhost asycn io
patch. I can make a try for TX only.

Thanks
Shirley
