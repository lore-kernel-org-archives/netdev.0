From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: WARN_ON_ONCE(work > weight) in napi_poll()
Date: Tue, 4 Jul 2017 13:49:53 +0000
Message-ID: <87wp7oia6j.fsf@kamboji.qca.qualcomm.com>
References: <26670dce-4dd2-f8e4-0e14-90d74257e739@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>,
 linux-wireless <linux-wireless@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <26670dce-4dd2-f8e4-0e14-90d74257e739@virtuozzo.com> (Andrey
 Ryabinin's message of "Fri, 30 Jun 2017 19:34:44 +0300")
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Andrey Ryabinin <aryabinin@virtuozzo.com> writes:

> I occasionally hit WARN_ON_ONCE(work > weight); in napi_poll() on a
> laptop with ath10k card.
>
>
> [37207.593370] ------------[ cut here ]------------
> [37207.593380] WARNING: CPU: 0 PID: 7 at ../net/core/dev.c:5274
> net_rx_action+0x258/0x360
> [37207.593381] Modules linked in: snd_hda_codec_realtek snd_soc_skl
> snd_hda_codec_generic snd_soc_skl_ipc snd_soc_sst_ipc snd_soc_sst_dsp
> snd_hda_ext_core snd_soc_sst_match snd_soc_core rtsx_pci_sdmmc
> mmc_core snd_pcm_dmaengine x86_pkg_temp_thermal snd_hda_intel uvcvideo
> kvm_intel videobuf2_vmalloc kvm snd_hda_codec snd_hwdep btusb
> videobuf2_memops btintel snd_hda_core videobuf2_v4l2 bluetooth
> irqbypass snd_pcm videobuf2_core crc32c_intel videodev mei_me mei
> rtsx_pci intel_lpss_pci intel_lpss_acpi intel_vbtn intel_lpss mfd_core
> tpm_tis intel_hid tpm_tis_core tpm efivarfs
> [37207.593430] CPU: 0 PID: 7 Comm: ksoftirqd/0 Not tainted 4.11.7 #28
> [37207.593432] Hardware name: Dell Inc. XPS 13 9360/0839Y6, BIOS 1.3.5 05/08/2017

What firmware and hardware versions exactly? The dmesg output when
ath10k loads is preferred. As you are using XPS 13 I'm guessing it's one
of QCA6174 family.

-- 
Kalle Valo
