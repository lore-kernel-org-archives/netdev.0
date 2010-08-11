From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Tue, 10 Aug 2010 20:28:02 -0700
Message-ID: <1281497282.3391.31.camel@localhost.localdomain>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
	 <1280442682.9058.15.camel@localhost.localdomain>
	 <4C525CD2.5080604@redhat.com>
	 <1280504771.9058.25.camel@localhost.localdomain>
	 <4C552DC4.5000600@redhat.com>
	 <1280764918.22830.7.camel@localhost.localdomain>
	 <4C56EE3D.1050203@redhat.com>
	 <1280766319.22830.24.camel@localhost.localdomain>
	 <4C56F318.7030409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C56F318.7030409@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Avi,

On Mon, 2010-08-02 at 19:32 +0300, Avi Kivity wrote:
> When are you seeing gup_fast() fall back to gup()?  It should be at
> most 
> once per page (when a guest starts up none of its pages are mapped,
> it 
> faults them in on demand). 

netperf/netserver latency results are pretty good for message size
between 1 bytes and 512 bytes when I have 64 bytes small copy.

However if I don't have any small copy , the ping RTT time is
unreasonable huge. Since we think it's better to have small message with
copy, so there will be no issue.

Thanks
Shirley
