From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Date: Thu, 1 Oct 2009 11:28:47 +0200
Message-ID: <20091001092847.GG5718@redhat.com>
References: <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com> <4ABD36E3.9070503@gmail.com> <4ABF33B2.4000805@redhat.com> <4AC3B9C6.5090408@gmail.com> <4AC46989.7030502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
        "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org,
        akpm@linux-foundation.org, hpa@zytor.com,
        Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com,
        alacrityvm-devel@lists.sourceforge.net
To: Avi Kivity <avi@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <4AC46989.7030502@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 01, 2009 at 10:34:17AM +0200, Avi Kivity wrote:
>> Second, I do not use ioeventfd anymore because it has too many problems
>> with the surrounding technology.  However, that is a topic for a
>> different thread.
>>    
>
> Please post your issues.  I see ioeventfd/irqfd as critical kvm interfaces.

I second that. AFAIK ioeventfd/irqfd got exposed to userspace in 2.6.32-rc1,
if there are issues we better nail them before 2.6.32 is out.
And yes, please start a different thread.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
