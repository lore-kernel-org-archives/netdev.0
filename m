From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 50/51] Check user supplied interface name
 lengths
Date: Tue, 15 Aug 2017 09:09:45 -0700
Message-ID: <20170815090945.62b2c4d7@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170812120510.28750-51-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37595 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751224AbdHOQJy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 12:09:54 -0400
Received: by mail-pg0-f52.google.com with SMTP id y129so8189691pgy.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 09:09:54 -0700 (PDT)
In-Reply-To: <20170812120510.28750-51-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:05:09 +0200
Phil Sutter <phil@nwl.cc> wrote:

> +void assert_valid_dev_name(const char *, const char *);

Not a fan of long function names.
=E2=80=9CI have only made this letter longer because I have not had the tim=
e to make it shorter."

Maybe just add a new function addattr_ifname() and add the checking there?
