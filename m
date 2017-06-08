From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 2/2(net.git)] stmmac: fix for hw timestamp of GMAC3 unit
Date: Thu, 8 Jun 2017 04:31:58 +0300
Message-ID: <CAHp75VfOhjLB96wf33CCFiEhxQ5ve3DX+GKiwUX-jB8FQCUB=w@mail.gmail.com>
References: <trinity-988824f2-9aed-4ed0-bc97-d78b13337cf5-1496825121649@3capp-webde-bs41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mario Molitor <Mario_Molitor@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <trinity-988824f2-9aed-4ed0-bc97-d78b13337cf5-1496825121649@3capp-webde-bs41>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 7, 2017 at 11:45 AM, Mario Molitor <Mario_Molitor@web.de> wrote:

>  exit:
> -       return ret;

> +       if (likely(ret == 0))
> +               return 1;
> +       else
> +               return 0;

else is redundant.


-- 
With Best Regards,
Andy Shevchenko
