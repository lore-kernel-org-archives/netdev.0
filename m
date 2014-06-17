From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/6] A step closer to RFC 6458 compliancy
Date: Tue, 17 Jun 2014 12:32:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DC3F@AcuExch.aculab.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49462 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932526AbaFQMd3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 08:33:29 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01513-08 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 13:33:20 +0100 (BST)
In-Reply-To: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geir Ola Vaagland
> Geir Ola Vaagland (6):
>   Support for SCTP_RECVRCVINFO socket option
>   Support for SCTP_RCVINFO ancillary data
>   Support for SCTP_SNDINFO ancillary data
>   Support for SCTP_NXTINFO socket option
>   Support for receiving SCTP_NXTINFO ancillary data
>   Support for SCTP_DEFAULT_SNDINFO socket option
> 
>  include/net/sctp/structs.h  |  11 +-
>  include/net/sctp/ulpevent.h |   4 +
>  include/uapi/linux/sctp.h   |  46 ++++++++
>  net/sctp/socket.c           | 260 ++++++++++++++++++++++++++++++++++++++++++--
>  net/sctp/ulpevent.c         | 158 +++++++++++++++++++++++++++
>  5 files changed, 470 insertions(+), 9 deletions(-)

You need to make your C match the expected layout for kernel code.
In particular the whitespace rules.

	David
