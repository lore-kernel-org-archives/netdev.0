From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: generic 802.11 stack
Date: Thu, 9 Sep 2004 00:36:48 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040909043648.GJ31207@ruslug.rutgers.edu>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<200409072141.58893.vkondra@mail.ru>
	<20040907121019.733cc7aa.davem@davemloft.net>
	<200409072254.18804.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <200409072254.18804.vkondra@mail.ru>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2004 at 10:54:12PM +0300, Vladimir Kondratiev wrote:
> Anyone doing drivers for Intersil and Broadcom, are you on this list? Would 
> you join this effort?

In regards to Intersil 802.11g chipsets and new card support lead by the 
prism54 project, we haven't yet been provided with specs for the new 
softmac chipsets nor an updated source base but regardless I'm sure
we'll have to do a lot of cleaning/code nuking so sure why not.

We still have work to complete for prism54 and have nothing solid to work on
for a new softmac driver so participation with this effort may take a
while. If we don't hear back from Conexant in regards to the softmac
chipsets we will just have to use that old code posted earlier as base
for new development.

The softmac driver is "supposed" to be backward compatible with the
fullmac chipsets as well as with the firmware for them but I've heard
this backward compatiblity has been broken. This is unfortunate as if
this backward compatibility does not work it would be the requirement of
two separate prism54-type drivers.

We've also discussed re-writing our current fullmac driver for two
purposes:

1. Dual licensing (FBSD/GPL)
2. Start using/help writing this new generic 802.11 stack
3. Cleaning the code

It may be the case that we can just re-write the fullmac driver in hopes
that we can later adapt/include softmac code. We need questions answered
for this though so hopefully Conexant will start talking to us again.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
