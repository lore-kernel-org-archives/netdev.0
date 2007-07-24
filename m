From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: revised make xfrm_audit_log more generic patch
Date: Tue, 24 Jul 2007 11:17:58 -0500
Message-ID: <1185293878.15699.358.camel@faith.austin.ibm.com>
References: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
	 <200707241104.56310.sgrubb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, linux-audit@redhat.com
To: Steve Grubb <sgrubb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:58100 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbXGXQUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 12:20:05 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6OGK5gL020771
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 12:20:05 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6OGK4OP126402
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 10:20:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6OGK4hN029479
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 10:20:04 -0600
In-Reply-To: <200707241104.56310.sgrubb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 11:04 -0400, Steve Grubb wrote:

> > +       audit_log_format(audit_buf, "%s: auid=%u", buf, auid);
> >  
> >         if (sid != 0 &&
> >                 security_secid_to_secctx(sid, &secctx, &secctx_len) == 0)
> 
> The operation in buf will not be parsed by the user space tools. Let's 
> use "op=%s " where you have "%s: " above. Audit record fields are name=value 
> and fields separated by spaces. "op" is what we are using in other places to 
> mean operation. 
> 
> I know its a change from the records above, but we previously had some detail 
> about what operation was being performed by the record type and this did not 
> matter so much. Now that we only have one event type, the meaning of the 
> event being recorded needs to be parsable and in a field. 
> 
> It also wouldn't hurt to change the text being sent to this function to have a 
> hyphen instead of a space, so "SPD delete" becomes "SPD-delete". This keeps 
> the parser happy.
> 
> This patch otherwise looks good.

Sounds good. I will make the changes and resend. 
Thanks!!

Joy
