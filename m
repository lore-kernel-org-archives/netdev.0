From: "Rask Ingemann Lambertsen" <rask@sygehus.dk>
Subject: Re: small e100 ethernet driver problem -> %d
Date: Fri, 23 May 2003 14:29:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030523132143.M3935@sygehus.dk>
References: <20030520140341.GY30683@gsib.sl.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anatoly Pugachev <mator@gsib.ru>
In-Reply-To: <20030520140341.GY30683@gsib.sl.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 20 May 2003 18:03:41 +0400, Anatoly Pugachev wrote
> module works fine, but notice %%d in the output, should be missprint 
> and easy to fix.

It is a misfeature (i.e. a deliberate bug) in the log daemon. Starting 
sometime in the 2.3 kernel series, the PIIX IDE code mistakenly used

printk("... not 100% native mode ...");

which would then correctly log as "not 100 ative mode". It took a while 
before the printk() string was corrected to "100%% native" and unfortunately, 
the log daemon changed before the IDE code was fixed.

eth%d is the result from not calling init_etherdev() or so.

-- 
Regards,
Rask Ingemann Lambertsen
