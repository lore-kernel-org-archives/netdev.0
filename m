From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH Linux-2.6.8-rcx] prism54 Bug - Fix
	frequency reporting
Date: Wed, 11 Aug 2004 06:38:17 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040811103817.GA26262@ruslug.rutgers.edu>
References: <200408111225.24892.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <200408111225.24892.margitsw@t-online.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 11, 2004 at 12:25:24PM +0200, Margit Schubert-While wrote:
> 2004-08-11 Margit Schubert-While <margitsw@t-online.de>
> 
> * prism54_get_freq is incorrectly returning channel
> * and not frequency. Wireless tools detect this, but
> * other programs do not, leading to insane reported
> * values. (As Jean documents, drivers should really be
> * reporting the frequency).
> * An example is wavemon.
> 
> Margit

This fixes capturing frequency for wpa_supplicant as well.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
