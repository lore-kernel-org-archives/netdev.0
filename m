From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Thu, 29 May 2014 11:12:09 +0200
Message-ID: <5386F9E9.7000401@redhat.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com> <538644AE.90807@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1724FA96@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Vlad Yasevich'" <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933420AbaE2JMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 05:12:18 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724FA96@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2014 11:03 AM, David Laight wrote:
...
> The wireshark trace does show zero for all the transmitted SCTP
> checksums. But the system works fine for hours, so I don't really
> believe that is causing the packets to be lost.

Btw, sounds like checksumming turned off via module param.
I think we should probably remove that debugging feature
eventually ... :/
