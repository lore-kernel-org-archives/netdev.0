From: Avi Kivity <avi@redhat.com>
Subject: Re: AlacrityVM benchmark numbers updated
Date: Wed, 26 Aug 2009 22:23:12 +0300
Message-ID: <4A958BA0.2000801@redhat.com>
References: <4A948962.7090909@gmail.com> <4A950B75.5020409@redhat.com> <4A95822D.9060207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A95822D.9060207@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/26/2009 09:42 PM, Gregory Haskins wrote:
> Actually, I have already look at this and it does indeed seem better to
> use switch_mm+gupf() over gup() by quite a large margin.  You could then
> couple that with your DMA-engine idea to potentially gain even more
> benefits (though probably not for networking since most NICs have their
> own DMA engine anyway).
>
>    

For tx, we'll just go copyless once we plumb the destructors properly.  
But for rx on a shared interface it is impossible to avoid the copy.  
You can only choose if you want it done by the cpu or a local dma engine.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

