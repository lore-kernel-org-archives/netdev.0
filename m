From: margitsw@t-online.de (Margit Schubert-While)
Subject: wireless.h and sparse warnings
Date: Sat, 09 Oct 2004 16:01:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20041009155130.02572408@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Problem getting rid of sparse warnings.
Using wireless_send_event for a custom event
(eg, in prism54 driver), we need to use the union
"iwreq_data" (from wireless.h), specifically the
"data.pointer" member initialized to a kmalloc'd
area. Therein lies the problem as "data.pointer"
has attribute "__user"; so a
"iwrqun.data.pointer = memptr;"
throws sparse warnings.

Anybody got any ideas ?

Margit
