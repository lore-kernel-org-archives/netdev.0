From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 19:30:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409021930.18414.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004, Nishanth scribeth:
> A grep of drivers/net/wireless/prism54 for schedule_timeout showed three
> occurrences (in 2.6.9-rc1-bk7):
> islpci_dev.c:   schedule_timeout(50*HZ/1000);
> islpci_dev.c:           remaining = schedule_timeout(HZ);
> islpci_mgt.c:           timeleft = schedule_timeout(wait_cycle_jiffies);
> The first is removed by my patch.
> The second & third are potentially bugs as there is no
> set_current_state() preceding the call to schedule_timeout(). As per the
> source:

Nope, look a few lines above:
DEFINE_WAIT() and prepare_to_wait().

Margit
