From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 19:52:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409021952.18280.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004, Nishanth scribeth:
> Keep in mind that msleep_interruptible() is also
> (hopefully) being pushed to the kernel soon

I think you need this for your current patch set ;-)
eg. In e100, where you replace an interruptible timeout:
> @@ -2020,8 +2016,7 @@

I don't think that's correct.

Margit
