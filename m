From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: IP More Fragements bit problem.
Date: Mon, 14 Feb 2005 13:37:25 +0100
Message-ID: <200502141337.25499.vincent.roqueta@ext.bull.net>
References: <200502111708.16024.vincent.roqueta@ext.bull.net> <420CFD1F.2060701@us.ibm.com> <200502140929.24379.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <200502140929.24379.vincent.roqueta@ext.bull.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
> >
> > Silly question, but are you absolutely sure that the original wasn't
> > actually ABCDE?
>
> No, we are not sure. It is possible we lack the last fragement witch is not
> marked with the MF bit.

You are right. All fragments are not sent !!! And so the last fragment 
received is not the last fragment sent by the client. The MF is set and that 
is correct.

Sorry :/


Vincent
