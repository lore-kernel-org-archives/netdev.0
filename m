From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 15:10:43 -0500
Message-ID: <1111781443.1092.631.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
	 <1111550254.1089.21.camel@jzny.localdomain>
	 <4241C478.5030309@dsl.pipex.com>
	 <1111607112.1072.48.camel@jzny.localdomain>
	 <4241D764.2030306@dsl.pipex.com>
	 <1111612042.1072.53.camel@jzny.localdomain>
	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>
	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>
	 <1111663947.1037.24.camel@jzny.localdomain>
	 <1111665450.1037.27.camel@jzny.locald
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <42446DB2.9070809@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 14:59, Andy Furniss wrote:
> jamal wrote:
> 
> > I gotta give it to you - you have helped isolate more bugs in this one
> > session than all others in the past summed up.
> 
> LOL - there may be more to come,

;-> You know what they say: 
Trust in God only (if you believe in one) and not software. 
And youve probably heard the famous last words just before the big crush
which sound like "that was the last bug" ;->

>  though I haven't used CONNMARK before 
> and may be missing something about it - and maybe there is a tc way to 
> look at connmark anyway?
> 

I dont think connmark will work - yet. Patrick? I think you need
something attached on the skb that is derived off the netfilter
contracking code for it to be usable.

Things will work once the  "action track" is in place; i.e you would
then say:
"match xxx .. \
 action track \
 action connmark"

If i was to prioritize my time for new actions - how important is this?
I also wish someone else would start writting some of these actions ;->
Wanna right the tracking one? I could help - wink.

cheers,
jamal
