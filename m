From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: netfilter: Hung task
Date: Mon, 19 Mar 2012 18:13:39 +0200
Message-ID: <CA+1xoqdo5zvUe+=BYr42iEEq9mU=kd1zVxrGhQc0sNYqbpBkNQ@mail.gmail.com>
References: <CA+1xoqfCTXxXsbfUjttuOVutyD_FzYS8PoOoAOOtB72P8SwdVg@mail.gmail.com>
 <20120318141943.GA28850@1984> <CA+1xoqcQYqCgQb=1M5PVkm=6SBhV2oJxJ2CtBp=gAvZM36Kc2Q@mail.gmail.com>
 <20120319002811.GA30408@1984> <alpine.DEB.2.00.1203190854560.16879@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	davem@davemloft.net, Dave Jones <davej@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1203190854560.16879@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 19, 2012 at 3:56 PM, Christoph Lameter <cl@linux.com> wrote:
> This is sually something causing memory corruption. Please enable
> debugging to get backtrace that help to debutg this. CONFIG_SLUB_DEBUG_ON
> will do the trick or passing "slub_debug" on the kernel command line.

The kernel was compiled with SLUB_DEBUG_ON, there's nothing coming out
of the slub before that hang message, nor after it.
