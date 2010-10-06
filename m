From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] eicon: make buffer larger
Date: Wed, 6 Oct 2010 14:11:20 +0200
Message-ID: <20101006121119.GA11681@bicker>
References: <20101004192459.GE5692@bicker> <alpine.DEB.2.00.1010060923120.29107@justus.melware.de> <20101006074714.GE5409@bicker> <alpine.DEB.2.00.1010061019480.29404@justus.melware.de> <20101006083117.GF5409@bicker> <alpine.DEB.2.00.1010061043550.29582@justus.melware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Armin Schindler <armin@melware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010061043550.29582@justus.melware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 06, 2010 at 10:44:47AM +0200, Armin Schindler wrote:
>>   927    strcpy (clients[id].drvName,     tmp);
>>   928    strcpy (clients[id].Dbg.drvName, tmp);
>>                               ^
>>                    this buffer is only 16 chars
>
> Now I understand. You are right. So the fix would be to change these  
> strcpy() to e.g. strncpy() or similar.
>

We need more than 16 characters to store the information.  What is the
problem with just making the buffer larger?

regards,
dan carpenter

> Armin
