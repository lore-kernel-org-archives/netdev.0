From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATH] atm/clip device discovery on init not needed
Date: Thu, 15 Jan 2004 00:44:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115004404.51b00808.davem@redhat.com>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
	<20040114164338.1f0d15e4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, chas@cmf.nrl.navy.mil,
        linux-atm-general@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040114164338.1f0d15e4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 16:43:38 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Atm/clip driver was doing device list walk to find interfaces.
> This will no longer be needed now that events are replayed when
> register_netdevice_notifier is called (see earlier patch)

Applied, thanks Stephen.
