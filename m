From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: SFQ: Reordering?
Date: Tue, 10 May 2005 00:14:47 +0100
Message-ID: <427FEEE7.2040104@dsl.pipex.com>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch> <427BFB72.7080407@trash.net> <20050507005851.GK28419@postel.suug.ch> <427C19C3.5030304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Asim Shankar <asimshankar@gmail.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427C19C3.5030304@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> It would be interesting to see this in real-life, when a single flow
> is hashed to multiple buckets (it can be even more than two) and
> each bucket has some packets queued, the result should look pretty
> chaotic.

It certainly hurts latency if used for ingress shaping, perturb nearly 
always makes the sender backoff and then burst.

Andy.
