From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 08:50:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409020850.38177.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I agree with Jean and add the following :
You are assuming HZ = 1000.
In 2.4, HZ = 100 (And in 2.6, HZ is not necessarily = 1000).
The prism54 code base is identical between 2.4/2.6 and is
maintained as such in the project.
Therefore, I look forward to your implementation of msleep()
in 2.4  ;-)

Margit
