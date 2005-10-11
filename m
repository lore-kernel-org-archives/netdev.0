From: Andi Kleen <ak@suse.de>
Subject: Re: Timeline of IPoIB performance
Date: Tue, 11 Oct 2005 02:51:22 +0200
Message-ID: <200510110251.22442.ak@suse.de>
References: <1128672413.13948.326.camel@localhost>
	<20051010212652.GG9613@esmail.cup.hp.com>
	<20051010233054.GA11213@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Grant Grundler <iod00d@hp.com>
In-Reply-To: <20051010233054.GA11213@esmail.cup.hp.com>
Content-Disposition: inline
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

On Tuesday 11 October 2005 01:30, Grant Grundler wrote:
> On Mon, Oct 10, 2005 at 02:26:52PM -0700, Grant Grundler wrote:
> ...
>
> > If it's interleaving, every other cacheline will be "local".
>
> ISTR AMD64 was page-interleaved but then got confused by documents
> describing "128-bit" 2-way interleave. I now realize the 128bit
> is refering to interleave between two "banks" of memory behind
> each memory controller. ie 2 * 128-bit provides in the 32-byte
> cacheline size that most x86 programs expect.

The cache line size on K7 and K8 is 64 bytes.

> Anyway, I'm hoping that we'll see a consistent result if node interleave
> is turned off.

Yes usually a good idea.


-Andi
