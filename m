From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 15:21:25 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: mcgrof@studorgs.rutgers.edu, netdev@oss.sgi.com,
	jgarzik@pobox.com, vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

I disagree with this.
We don't need parameter parsing either in the driver or in
wireless.c.
There is a perfectly good infrastructure in wireless tools iwpriv.c
Take a look at around line 375 in iwpriv.c for the
existing example of IW_PRIV_TYPE_FLOAT.
This could be adapted for this purpose (IW_PRIV_TYPE_BITRATE ?)
and (mis)use the iw_freq structure to pass the values and extra info.

This is probably the least invasive and can be tied to a particular WE
release.

Also we seem to have forgotten the 5 GHz band with 72, 100, 108
rates and only ofdm allowable.

Margit
