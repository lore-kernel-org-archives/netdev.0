From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Tue, 30 Nov 2004 13:52:15 -0600
Message-ID: <200411301352.15927.jdmason@us.ibm.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41A4E2C9.4070502@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <41A4E2C9.4070502@phekda.gotadsl.co.uk>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 24 November 2004 01:36 pm, Richard Dawe wrote:
> Hello.
>
> I don't know if it will help, but FreeBSD's re driver source code is here:
>
> http://www.freebsd.org/cgi/cvsweb.cgi/src/sys/dev/re/if_re.c?only_with_tag=
>HEAD
>
> Have you ever looked at that? It has some interesting comments about the
> maximum Jumbo packet length and vendor-specific registers in the 8110.
>
> Thanks, bye, Rich =]

I've experimented with the value of EarlyTxThld, and have been able to get it 
to work upto a MTU of 8000.  I still need to do some more experimentation to 
find the optimal value (and see if modifying any other registers will help 
this).

-- 
Jon Mason
jdmason@us.ibm.com
