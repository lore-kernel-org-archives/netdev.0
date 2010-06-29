From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 0/2] cxgb4vf: small fixes to new driver
Date: Tue, 29 Jun 2010 15:52:14 -0700
Message-ID: <201006291552.14816.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3368 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab0F2W5m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:57:42 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5TMvg2m018102
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 15:57:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From d9aed637fc8a9f1bf1bccf6f23aed0342870f868 Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Tue, 29 Jun 2010 15:41:14 -0700
Subject: [PATCH 0/2] cxgb4vf: small fixes to new driver

  In my cxgb4vf driver testing I got very "lucky" and the use of an
incorrect shift factor just happened to work for the packet size I was
using. (sigh) (All of this happened because I had to translate our internal
version of the driver to use the different constant names used in the
kernel.org tree.)

Casey Leedom (2):
  Remove obsolete comment about the lack of a TX Timer Callback --
    which we now _do_ have ...

  Use correct shift factor for extracting the SGE DMA Ingress Padding  
    Boundary.  Was accidentally using the register field's shift which
    was close enough (4 instead of the propper value of 5) that it
    actually sort of worked for various packet sizes ...

 drivers/net/cxgb4vf/sge.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

