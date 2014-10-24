From: Dmitry Voytik <voytikd@gmail.com>
Subject: Re: [PATCH 1/2] staging: lustre: lnet: lnet: do not initialise 0
Date: Fri, 24 Oct 2014 22:57:19 +0400
Message-ID: <20141024185719.GA10175@ubuntuvm>
References: <20141018040330.GA23492@vasu-Inspiron-3542>
 <54429DAB.4060906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Balavasu <kp.balavasu@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54429DAB.4060906@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 18, 2014 at 09:04:43PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 10/18/2014 8:03 AM, Balavasu wrote:
> 
> >-static int check_routers_before_use = 0;
> >+static int check_routers_before_use = {0};
> 
>    Eh? I thought {} is only for arrays/structures...

It seems like this is from C++. In C++11 you can even drop '=' like
this:
	int i {0};
;)

WBR,
voyt
