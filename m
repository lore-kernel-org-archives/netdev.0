From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 14:17:41 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208131017.OAA20516@sex.inr.ac.ru>
References: <20020813053704.GA14788@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020813053704.GA14788@anakin.wychk.org> from "Geoffrey Lee" at Aug 13, 2 03:37:04 pm
List-Id: netdev.vger.kernel.org

Hello!

> (1) no signals (so it runs the sighandler but doesn't return from the
> sys call until it completes), non-blocking socket:
> 
> 
> -EINPROGRESS, -EALREADY, -EISCONN, in that order. Never returns 0.


socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 3
fcntl64(0x3, 0x4, 0x800, 0x400151cc)    = 0
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = -1 EINPROGRESS (Operation now in progress)
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = -1 EALREADY (Operation already in progress)
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = -1 EALREADY (Operation already in progress)
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = -1 EALREADY (Operation already in progress)
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = -1 EALREADY (Operation already in progress)
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = 0
connect(3, {sin_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("193.233.7.75")}}, 16) = -1 EISCONN (Transport endpoint is already connected)

> Is that what you expected?

Well, it proves that one of us makes tests not on linux.

Alexey
