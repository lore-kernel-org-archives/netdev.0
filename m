From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 3/6] Support for SCTP_SNDINFO ancillary data
Date: Tue, 17 Jun 2014 10:29:07 -0400
Message-ID: <53A050B3.3060203@gmail.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com> <1403006273-27859-4-git-send-email-geirola@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1725DC7D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:63259 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbaFQO3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 10:29:11 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725DC7D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2014 08:38 AM, David Laight wrote:
> From: Geir Ola Vaagland
> ...
>> +		case SCTP_SNDINFO:
>> +			/* SCTP Socket API Extension
>> +			 * 5.3.4 SCTP Send Information Structure (SCTP_SNDINFO)
>> +			 *
>> +			 * This cmsghdr structure specifies SCTP options for
>> +			 * sendmsg(). This structure and SCTP_RCVINFO replaces
>> +			 * SCTP_SNDRCV which has been depleted.
> 
> What do you mean by 'depleted'?

I think he meant deprecated.

-vlad

> Support for it cannot be removed because it will break existing
> applications.
> 
> 	David
> 
> 
> 
