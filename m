From: "Cornelia Huck" <COHUCK@de.ibm.com>
Subject: Re: Bug in qeth in 2.6
Date: Thu, 4 Sep 2003 18:01:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF58BF7438.64133064-ONC1256D97.00578776-C1256D97.005801DC@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Utz Bacher <utz.bacher@de.ibm.com>,
   Pete Zaitcev <zaitcev@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pete Zaitcev <zaitcev@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

sorry, I still don't see it...

> 2.4 was like this:
>
>            result = 0;
>            for (all in list) {
>                        if (something)
>                                    result = QETH_VERIFY_IS_SOMETHING;

and it stops here if something...

>            }

... and here follows a second loop over the list, looking for foo().

>
> 2.6 is:
>
>            result = 0;
>            for (all in list) {
>                        result = (something)? QETH_VERIFY_IS_SOMETHING:
foo();

and here it stops if something or foo()...

>            }

...no second loop here.

Since it's either something or foo(), this looks like the same behaviour to
me.

Best regards / Mit freundlichen Gruessen

Cornelia Huck
zLinux Developer
Tel.: +49-7031-16-4837, Mail: cohuck@de.ibm.com
