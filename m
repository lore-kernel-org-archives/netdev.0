From: John David Anglin <dave.anglin@bell.net>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 18:53:32 -0500
Message-ID: <38881C74-60B0-40BC-83ED-052889705FC5@bell.net>
References: <20151025114934.GA11108@ls3530.box> <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com> <56393D46.6060903@gmx.de> <D6403D2F-339E-4986-ABED-26455A157F7A@alum.mit.edu>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Helge Deller <deller@gmx.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Network Development <netdev@vger.kernel.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <D6403D2F-339E-4986-ABED-26455A157F7A@alum.mit.edu>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-11-03, at 6:43 PM, Guy Harris wrote:

> 
> On Nov 3, 2015, at 3:03 PM, Helge Deller <deller@gmx.de> wrote:
> 
>> Sadly it's nowhere clearly documented how big the L1 cacheline of parisc really is.
> 
> To which particular PA-RISC processor are you referring?  It might not be the same on all processors.
> 
> If openpa.net is to be believed, then:
> 
> The 7100LC has 32 byte cache lines on the off-chip cache:
> 
> 	http://www.openpa.net/pa-risc_processor_pa-7100lc.html
> 
> and the 8500 has "32 or 64 Byte cache line size", which may be referring to the on-chip caches:
> 
> 	http://www.openpa.net/pa-risc_processor_pa-8500.html

Yes, this is correct but these numbers relate to the memory interface.  The PA8800 and PA8900 have 128 byte
memory interfaces.  These numbers are reported by firmware PDC calls.  This whole discussion started when I
suggested that we needed to bump L1_CACHE_BYTES to 128 bytes on PA8800 and PA8900 processors.

--
John David Anglin	dave.anglin@bell.net



