From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: ipset losing entries on its own
Date: Tue, 12 Sep 2017 17:24:55 +0530
Message-ID: <CAA5aLPgPU5u6k+rB+5zNCsqp3UBnx3oZoSv_0drNCRK0tcSSBQ@mail.gmail.com>
References: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
 <c7abf292ac5e6202993a10a66537141e@nuclearcat.com> <CAA5aLPgUcrUpqJJ8stu1543LBy0qekgQDuJyokqLPP0TirySgg@mail.gmail.com>
 <CAA5aLPiENU+k0=tH1jPvSdmdEcMDFfgk0FQcHxWvz8tYCaNZzg@mail.gmail.com> <CAA5aLPgM9=VU4Cysy-LtN-uXPqvG00X2v8MP9EM5RtPVB6tGvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34960 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdILLy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 07:54:56 -0400
In-Reply-To: <CAA5aLPgM9=VU4Cysy-LtN-uXPqvG00X2v8MP9EM5RtPVB6tGvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can somebody throw more light on this? How it is possible (without a
bug) that for exactly same set of IPs, at time IPSET HASHSIZE remains
at 1024 and at times it increases to 2048?

As a workaround I am running the show setting HASHSIZE as 16384 at
times of IPSET creation itself, and till now (its more than 4 days)
the issue has not repeated.

But this need to be addressed, right?
