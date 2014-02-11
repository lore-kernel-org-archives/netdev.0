From: "Steinar H. Gunderson" <sesse@samfundet.no>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Tue, 11 Feb 2014 22:59:28 +0100
Message-ID: <20140211215928.GA7862@sesse.net>
References: <20140211215510.GA6994@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, itk-intern@samfundet.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:60829 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaBKV7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 16:59:30 -0500
Content-Disposition: inline
In-Reply-To: <20140211215510.GA6994@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 10:55:11PM +0100, Steinar H. Gunderson wrote:
> but on 3.13.1, no such route shows up. I can add it manually, though.

Correction; I can add it manually, but only to one GRE device at a time:

  root@altersex:~$ ip -6 route add fe80::/64 dev k_molvenfinnoy
  root@altersex:~$ ip -6 route add fe80::/64 dev k_sessesveits
  RTNETLINK answers: File exists
  root@altersex:~$ ip -6 route del fe80::/64 dev k_molvenfinnoy
  root@altersex:~$ ip -6 route add fe80::/64 dev k_sessesveits
  root@altersex:~$

/* Steinar */
-- 
ITK-pang
http://www.sesse.net/
