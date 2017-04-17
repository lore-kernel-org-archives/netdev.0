From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: cx89x0: move attribute declaration before struct
 keyword
Date: Mon, 17 Apr 2017 16:09:42 -0400 (EDT)
Message-ID: <20170417.160942.2196583103295700079.davem@redhat.com>
References: <20170417062032.22764-1-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shc_work@mail.ru, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan@agner.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170417062032.22764-1-stefan@agner.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Agner <stefan@agner.ch>
Date: Sun, 16 Apr 2017 23:20:32 -0700

> The attribute declaration is typically before the definition. Move
> the __maybe_unused attribute declaration before the struct keyword.
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>

Well, I see if just as often after the variable name too:

net/irda/iriap.c:static const char *const ias_charset_types[] __maybe_unused = {
net/irda/irlap.c:static const char *const lap_reasons[] __maybe_unused = {
net/irda/irlap_event.c:static const char *const irlap_event[] __maybe_unused = {
net/irda/irlmp_event.c:static const char *const irlmp_event[] __maybe_unused = {

Or after the struct:

drivers/net/phy/ste10Xp.c:static struct mdio_device_id __maybe_unused ste10Xp_tbl[] = {
drivers/net/phy/teranetics.c:static struct mdio_device_id __maybe_unused teranetics_tbl[] = {
drivers/net/phy/vitesse.c:static struct mdio_device_id __maybe_unused vitesse_tbl[] = {

So unless we decide tree wide to do it in one order or another, such changes
are largely a waste of time.

Sorry I'm not applying this patch.
