From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 15:26:25 -0400
Message-ID: <4C2B9A61.1000208@athenacr.com>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmatthews@greenplum.com,
	Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:54013 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754953Ab0F3T00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 15:26:26 -0400
In-Reply-To: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2010 02:04 PM, Ivan Novick wrote:
> I am wondering why did the sender not send more data?  If the sender
> was to send more data and extend the window then it would seem the
> duplicate acks or SACKS should trigger fast retransmit.

Hi Ivan,

Like you said, the receive window can't explain why the sender wouldn't
send. The congestion window is another possible reason why the sender
might not send, though it's sorta impossible to tell if that's really
it from a small tcpdump. Maybe investigating the details of congestion
control might yield something?

HTH,
-Brian
