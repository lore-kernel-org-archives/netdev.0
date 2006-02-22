From: Nikolaus Filus <nfilus@gmx.net>
Subject: Re: no carrier detection after resume from swsusp (8139too)
Date: Wed, 22 Feb 2006 16:12:14 +0100
Message-ID: <200602221612.14631.nfilus@gmx.net>
References: <200602212312.23903.nfilus@gmx.net>
	<20060221234947.GA29806@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: networkmanager-list@gnome.org,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <networkmanager-list-bounces@gnome.org>
To: netdev@vger.kernel.org
In-Reply-To: <20060221234947.GA29806@electric-eye.fr.zoreil.com>
Content-Disposition: inline
List-Unsubscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=unsubscribe>
List-Archive: <http://mail.gnome.org/archives/networkmanager-list>
List-Post: <mailto:networkmanager-list@gnome.org>
List-Help: <mailto:networkmanager-list-request@gnome.org?subject=help>
List-Subscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=subscribe>
Sender: networkmanager-list-bounces@gnome.org
Errors-To: networkmanager-list-bounces@gnome.org
List-Id: netdev.vger.kernel.org

Cc: networkamanger-list, as it seems now to be related to nm

On Wednesday 22 February 2006 00:49, Francois Romieu wrote:
> (owner of http://bugzilla.kernel.org/show_bug.cgi?id=5681 Cc:ed)
>
> Nikolaus Filus <nfilus@gmx.net> :
> [...]
>
> > I'm using linux 2.6.14.3 with swsusp2 2.2rc14 (not the most new
> > ones). Since I'm using NetworkManager, which switches and manages my
> > wired and wireless devices, I have to reload 8139too after resume,
> > before plugin events of wired network are recognized. Some other
> > users of NM are reporting similar problems.
>
> May I assume that your 8139too device does not need to be reloaded when
> you suspend/resume and NM is not used ?

I didn't look enough on this issue before.

After resume, I get "invalid argument" from
/sys/class/net/eth1/carrier. Reloading the driver *OR* restarting
networkmanager solves the problem! Is it possible a process like nm blocks 
some ressources, which are re-initialised by reloading the driver or 
restarting nm? Notice, that just stopping nm is not enough.

Thanks in advance,

Nikolaus
