From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/6] Support for SCTP_SNDINFO ancillary data
Date: Tue, 17 Jun 2014 14:42:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DDDD@AcuExch.aculab.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com>
 <1403006273-27859-4-git-send-email-geirola@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725DC7D@AcuExch.aculab.com>
 <53A050B3.3060203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52104 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932973AbaFQOnc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 10:43:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30473-01 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 15:43:24 +0100 (BST)
In-Reply-To: <53A050B3.3060203@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 06/17/2014 08:38 AM, David Laight wrote:
> > From: Geir Ola Vaagland
> > ...
> >> +		case SCTP_SNDINFO:
> >> +			/* SCTP Socket API Extension
> >> +			 * 5.3.4 SCTP Send Information Structure (SCTP_SNDINFO)
> >> +			 *
> >> +			 * This cmsghdr structure specifies SCTP options for
> >> +			 * sendmsg(). This structure and SCTP_RCVINFO replaces
> >> +			 * SCTP_SNDRCV which has been depleted.
> >
> > What do you mean by 'depleted'?
> 
> I think he meant deprecated.

Hmm.... that isn't going to work well, is it!

I presume the 'standard' only requires that the structure contain
the required fields?
Which probably means it could contain the required padding to make
it binary compatible with the existing 'struct sctp_sndrcvinfo'
(which also contains pad bytes!)

	David
