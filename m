From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: prism54: fix wpa_supplicant frequency parsing
Date: Mon, 23 Aug 2004 16:25:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823202511.GG22126@ruslug.rutgers.edu>
References: <5.1.0.14.2.20040822195310.00b023e8@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20040822195310.00b023e8@pop.t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 22, 2004 at 07:53:48PM +0200, Margit Schubert-While wrote:
> Eeek, iwconfig now shows :
> Mode:Managed  Frequency:2462GHz  Access Point: 00:09:5B:D0:34:BC
> instead of :
> Mode:Managed  Frequency:2.462GHz  Access Point: 00:09:5B:D0:34:BC

Sorry, the first change was unnecessary, the second was. Fixed in CVS,
now all displays nice (iwconfig, iwlist eth0 scan, iwlist eth0 freq).

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
