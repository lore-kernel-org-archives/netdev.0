From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: port mirror on dsa switches?
Date: Thu, 16 Mar 2017 09:47:50 -0700
Message-ID: <a4308ccd-4bd3-d8f5-e9d1-c6dcb16c57bc@gmail.com>
References: <CAJGZr0JzRZHTkdKCqFrwAG5fj-j3Ez2DYVOygiE9oQ3BTHZ4FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Maxim Uvarov <muvarov@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:35161 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753095AbdCPQry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 12:47:54 -0400
Received: by mail-qt0-f173.google.com with SMTP id x35so42588244qtc.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 09:47:53 -0700 (PDT)
In-Reply-To: <CAJGZr0JzRZHTkdKCqFrwAG5fj-j3Ez2DYVOygiE9oQ3BTHZ4FA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 03/16/2017 03:32 AM, Maxim Uvarov wrote:
> Hello,
> 
> Some dsa switches can support port mirror in hardware. Does somebody
> have any idea how to
> work with it from linux side in generic way?

It has been implemented with commit
f50f212749e8a28803af3628acbeb85ee0458ed5 ("net: dsa: Add plumbing for
port mirroring") and you can see an implementation example with the b53
driver.

For a DSA driver you should be implementing port_mirror_add and
port_mirror_del operations which provide you with the necessary
information. Hopefully the switch you are working with (mv88e6xxx?) is
also supportable using that API, if not, please submit changes to extend it.

Thanks!
-- 
Florian
