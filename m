From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: About MLDv2 specification
Date: Mon, 21 Jun 2004 14:06:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE94A3A87.01006C67-ON88256EBA.0072B763-88256EBA.0073CEA1@us.ibm.com>
References: <20040621181146.20bde98%hibi665@oki.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040621181146.20bde98%hibi665@oki.com>
To: Takashi Hibi <hibi665@oki.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Takashi,
        I believe your patch will work in suppressing empty
MODE_IS_INCLUDE, but in the event the report for an empty
MODE_IS_INCLUDE is the only record, it'll still go through the
timer for all the retransmits. I want to see how hard it'd be not
to start the report timer at all for this case, and also make sure
any other changes are taken care of. The patch looks ok to me
for the interim, though.

                                        +-DLS
