From: =?UTF-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure-tU7rkvAWjlwhT4uAktR2oQ@public.gmane.org>
Subject: Re: [PATCH 05/18] net: use ARRAY_SIZE
Date: Mon, 2 Oct 2017 21:22:14 -0400
Message-ID: <20171002212214.30d7013a@blatinox-laptop.localdomain>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
        <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
        <CAHp75VfC2e+h8GCiB-1Rbe=_z3siBBo0WfqEf3qz8yWh8Cm3RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Sathya Perla <sathya.perla-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Ajit Khaparde <ajit.khaparde-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Chi-Hsien Lin <chi-hsien.lin-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>,
        Wright Feng <wright.feng-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
        Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
        Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <
To: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHp75VfC2e+h8GCiB-1Rbe=_z3siBBo0WfqEf3qz8yWh8Cm3RQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2017 16:07:36 +0300
Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> > +       {&gainctrl_lut_core0_rev0, ARRAY_SIZE(gainctrl_lut_core0_rev0), 26, 192,
> > +        32},  
> 
> For all such cases I would rather put on one line disregard checkpatch
> warning for better readability.
I agree that it would be better. I didn't know that it was possible to
not follow this rule for anything else than a string.

I am waiting for more comments and I will send a v2.

Thank you,
Jérémy
