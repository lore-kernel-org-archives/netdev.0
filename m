From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: e1000 problem with NAPI?
Date: Tue, 1 Mar 2005 19:38:58 +0100
Message-ID: <20050301183858.GA15931@xi.wantstofly.org>
References: <20050301135931.GA14610@xi.wantstofly.org> <56a8daef05030110137b712879@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, robert.olsson@data.slu.se
To: John Ronciak <john.ronciak@gmail.com>
Content-Disposition: inline
In-Reply-To: <56a8daef05030110137b712879@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2005 at 10:13:34AM -0800, John Ronciak wrote:

> Lennert,

Hello,


> It sounds like you are running into a bug we had with NAPI in that
> e1000 driver.  Robert actually found it.  :-)  Please try the 5.7.6
> driver available from Sourceforge.  It has the fixed NAPI code in it.

Works much better, thanks.

It seems as if performance is much improved as well.  With the old
version (5.5.4-k2-NAPI), it would successfully receive ~350k pkts out
of a 1Mpkt back-to-back tinygram burst and drop ~650k.  With 5.7.6,
it receives ~780k and drops ~220k.  (82546GB dual copper GigE, dual
Xeon 2.4 w/HT on an intel SE7505VB2.)


cheers,
Lennert
