From: Jaume Catarineu <jaume.catarineu@upf.edu>
Subject: Kernel BUG: Qos seg. fault (part II)
Date: Tue, 25 May 2004 03:29:29 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B2BD99.4000500@upf.edu>
References: <20040524215346.73109.qmail@web80501.mail.yahoo.com> <1085436571.1041.69.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: hadi@cyberus.ca, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <1085436571.1041.69.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi again,

I've found another problem that seems strongly related to the first one.
In this case we just need a TBF root qdisc:

  tc qdisc add dev lo root handle 1: tbf rate 250kbit burst 5k limit 5k

After adding it, when we ask for the filters...

  tc filter show dev lo

Voil=E0!

   Segmentation fault

Does the patch provided by Dmitry arrange this? And the Jamal's patch?=20
Which is better?

Thanks,
Jaume,
