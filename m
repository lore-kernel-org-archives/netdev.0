From: Martin Devera <devik@cdi.cz>
Subject: Re: QoS _put, _get and _delete class ops semantic
Date: Thu, 11 Apr 2002 15:41:30 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.10.10204111453020.15162-100000@luxik.cdi.cz>
References: <Pine.GSO.4.30.0204101918200.24339-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0204101918200.24339-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

> > Unfortunately there is delete class op which seems to do
> > almost the same as put.
> > Do you know rationale behind it ? Why we have both put
> > and delete and what tc framework expect from qdisc ?
> 
> Alexey can give a better answer.

probably he could step in here ;)

> Typically put() is the backup for delete. Should delete fail
> to destroy because of reference counts being non-zero, put will catch it.

So that if I understand it correctly: delete can only assure
that class is "invisible" from now to subsequent gets/walks
and other uses and leave actual destroy to the last put.
Do you think that it is reasonable ?

> CBQ is an easier scheduler to see this. For a fun one look at the ATM
> scheduler.

I looked at them but I hate to blindly copy-n-paste code without
in-depth knowledge of interface's expectation. Especially when
yesterday (after year of flawless operation) someone made my
code oops during class deletion under high load ;-\

thanks, Martin
