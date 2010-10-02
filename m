From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: checkentry function
Date: Sat, 2 Oct 2010 13:59:30 +0200
Message-ID: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello there.
I've written checkentry function to check my new target, in this way:

[CHECK_ENTRY_CODE]
static bool xt_tarpit_check(const char *tablename, const void *entry,
                            const struct xt_target *target, void *targi=
nfo,
                            unsigned int hook_mask)
{
 if (strcmp(tablename, "filter"))   {
    printk(KERN_INFO "DEBUG: the tablename (not FILTER) is %s\n",tablen=
ame);
    return false;
  }
return true;
}
[/CHECK_ENTRY_CODE]

but it doesn't work.
In fact if I do:

iptables -A INPUT -t filter -s 192.168.0.1 -p tcp -j TAR

the printk prints this message: DEBUG: the tablename (not FILTER) is: =EF=
=BF=BD%H =EF=BF=BD

so: in the tablename i haven't the string "filter"...what' the matter?

--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
