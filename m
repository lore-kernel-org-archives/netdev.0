From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 21:17:17 +0200
Message-ID: <512E5BBD.2040803@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com> <20130227101354.15636ba5@nehalam.linuxnetplumber.net> <CA+mtBx85G3qD2_QP709kOMERP9T8v1W+ZNj12qnZWg_kALQtLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx85G3qD2_QP709kOMERP9T8v1W+ZNj12qnZWg_kALQtLg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/02/2013 20:47, Tom Herbert wrote:
> On Wed, Feb 27, 2013 at 10:13 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>>
>> Have you looked at netmap? Seems like a cleaner user API for this.
>>
> That might be a bit orthogonal to this.  I believe the intent it to
> allow spin polling from socket calls without API change.

Exactly.

BTW, an interesting alternative to netmap would be to map a VF into 
userspace. (you would need to pre-allocate DMA memory regions and all of 
that RDMA-like stuff)
