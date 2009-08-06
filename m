From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 18:50:59 +0300
Message-ID: <4A7AFBE3.5080200@redhat.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <4A7AE150.7040009@redhat.com> <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com> <200908061740.04276.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	alacrityvm-devel@lists.sourceforge.net,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200908061740.04276.arnd@arndb.de>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2009 06:40 PM, Arnd Bergmann wrote:
> 3. The ioq method seems to be the real core of your work that makes
> venet perform better than virtio-net with its virtqueues. I don't see
> any reason to doubt that your claim is correct. My conclusion from
> this would be to add support for ioq to virtio devices, alongside
> virtqueues, but to leave out the extra bus_type and probing method.
>    

The current conjecture is that ioq outperforms virtio because the host 
side of ioq is implemented in the host kernel, while the host side of 
virtio is implemented in userspace.  AFAIK, no one pointed out 
differences in the protocol which explain the differences in performance.

-- 
error compiling committee.c: too many arguments to function

