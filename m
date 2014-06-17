From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/6] Support for SCTP_RCVINFO ancillary data
Date: Tue, 17 Jun 2014 12:36:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DC64@AcuExch.aculab.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com>
 <1403006273-27859-3-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>
To: 'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49599 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932209AbaFQMhy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 08:37:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02047-06 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 13:37:46 +0100 (BST)
In-Reply-To: <1403006273-27859-3-git-send-email-geirola@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geir Ola Vaagland
...
> +struct sctp_rcvinfo {
> +	__u16 rcv_sid;
> +	__u16 rcv_ssn;
> +	__u16 rcv_flags;
> +	__u32 rcv_ppid;
> +	__u32 rcv_tsn;
> +	__u32 rcv_cumtsn;
> +	__u32 rcv_context;
> +	sctp_assoc_t rcv_assoc_id;
> +};

There are two pad bytes in the middle of the above.
You leak kernel data to userspace.

...
	David
