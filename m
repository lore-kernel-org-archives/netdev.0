From: Takashi Hibi <hibi665@oki.com>
Subject: Re: About MLDv2 specification
Date: Wed, 23 Jun 2004 15:38:17 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040623153817.bcc12ea%hibi665@oki.com>
References: <OFE94A3A87.01006C67-ON88256EBA.0072B763-88256EBA.0073CEA1@us.ibm.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: (Your message of "Mon, 21 Jun 2004 14:06:00 -0700")
  <OFE94A3A87.01006C67-ON88256EBA.0072B763-88256EBA.0073CEA1@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> :

> Takashi,
>         I believe your patch will work in suppressing empty
> MODE_IS_INCLUDE, but in the event the report for an empty
> MODE_IS_INCLUDE is the only record, it'll still go through the
> timer for all the retransmits. I want to see how hard it'd be not
> to start the report timer at all for this case, and also make sure
> any other changes are taken care of. The patch looks ok to me
> for the interim, though.
> 
>                                         +-DLS
> 

mld_send_cr() is called for retransmission of the report, but 
MODE_IS_INCLUDE is never used in this function. 
MODE_IS_INCLUDE is only used in mld_send_report(), and it is called
for the response to MLDv2 query.

Therefore no side effects occur, I think.

Regards,
Takashi Hibi
