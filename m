From: Grant Grundler <iod00d@hp.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 16:30:54 -0700
Message-ID: <20051010233054.GA11213@esmail.cup.hp.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost> <521x2tgrim.fsf@cisco.com>
	<20051010212652.GG9613@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Grant Grundler <iod00d@hp.com>
Content-Disposition: inline
In-Reply-To: <20051010212652.GG9613@esmail.cup.hp.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2005 at 02:26:52PM -0700, Grant Grundler wrote:
...
> If it's interleaving, every other cacheline will be "local".

ISTR AMD64 was page-interleaved but then got confused by documents
describing "128-bit" 2-way interleave. I now realize the 128bit
is refering to interleave between two "banks" of memory behind
each memory controller. ie 2 * 128-bit provides in the 32-byte
cacheline size that most x86 programs expect.

Anyway, I'm hoping that we'll see a consistent result if node interleave
is turned off.

sorry for the confusion,
grant
