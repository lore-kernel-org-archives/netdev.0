From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 17:20:22 -0500
Message-ID: <1111789221.1091.720.camel@jzny.localdomain>
References: <1111663947.1037.24.camel@jzny.localdomain>
	 <1111665450.1037.27.camel@jzny.localdomain>
	 <4242DFB5.9040802@dsl.pipex.com>
	 <1111749220.1092.457.camel@jzny.localdomain>
	 <42446DB2.9070809@dsl.pipex.com>
	 <1111781443.1092.631.camel@jzny.localdomain>
	 <20050325202014.GE3086@postel.suug.ch>
	 <1111783686.1089.661.camel@jzny.localdomain>
	 <20050325210102.GG3086@postel.suug.ch>
	 <1111787325.1092.690.camel@jzny.localdomain>
	 <20050325220349.GI3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050325220349.GI3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 17:03, Thomas Graf wrote:
> * jamal <1111787325.1092.690.camel@jzny.localdomain> 2005-03-25 16:48

> > 
> > What is the issue with htb+gred?
> 
> Remember your change to gred where you fixed a bug reported
> by stanford checker? I have two reports that this broke things
> for HTB+GRED although the change looks ok to me and is definitely
> needed.
> 

I dont remember the change ;-> But it may be time to make gred classful
as Werner was pushing for many years.

> I did not receive a reply from the original author of the
> code but I'm using it as a base. I simply imported the code
> into netconfig and changed it to use libnl for now. I left
> the ioctl there so it should be easy to have a compile flag
> to get back to ioctl.

selection of ioctls at compile time would be useful.

Just fork the project if they are not responding. I guarantee they will
show up when they hear you forked their code ;->
BTW, I have interest to run this code if you have made improvements i
dont mind playing with it.

cheers,
jamal
