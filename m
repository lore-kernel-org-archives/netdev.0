From: James Morris <jmorris@intercode.com.au>
Subject: Re: disablenetwork() syscall?
Date: Tue, 8 Jul 2003 09:59:32 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307080954170.5824-100000@excalibur.intercode.com.au>
References: <Pine.LNX.4.44.0307072237560.11843-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0307072237560.11843-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jul 2003, Pekka Savola wrote:

> Hi,
> 
> In a bugtraq thread, DJ Bernstein brought up an idea which I'm not sure 
> has been brought up in the past.

Such a feature already exists in SELinux.

>  I'm not sure whether it's feasible or 
> not, but at least it (and other methods to limit the functions of a 
> user-level code) might bear consideration.

This is precisely what LSM is for, so new security models can be 
implemented without any direct effect on the core kernel.


- James
-- 
James Morris
<jmorris@intercode.com.au>
