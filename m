From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2 2.6.20-070313
Date: Wed, 14 Mar 2007 21:42:40 +0100
Message-ID: <45F85E40.6050409@trash.net>
References: <20070313151549.332004c9@freekitty>	<200703141223.48927.arekm@maven.pl>	<45F7E527.6030307@trash.net>	<200703141316.05509.arekm@maven.pl>	<45F7EB5C.5010901@trash.net>
	<20070314101443.4347efdd@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Arkadiusz Miskiewicz <arekm@maven.pl>,
	lartc@mailman.ds9a.nl, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <20070314101443.4347efdd@freekitty>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 14 Mar 2007 13:32:28 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>RTA_* attributes aren't used for routing rules anymore inside
>>the kernel.
> 
> 
> But we need to keep them in iproute2 for back compatibility?

Not really for compatibility, its the numerical values that matter.
iproute hasn't been changed to use the FRA_* attributes for routing
rules, but it might be a good idea to do this before adding the next
RTA_* attribute since RTA_FWMASK doesn't have any meaning for routes
in the kernel, so the next RTA attribute we add could just use the
same value instead of leaving a hole.
