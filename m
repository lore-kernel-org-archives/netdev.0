From: "Hannes Eder" <hannes@hanneseder.net>
Subject: Re: [PATCH] isdn: eicon: fix sparse warning: make global functions static
Date: Sun, 14 Dec 2008 23:19:04 +0100
Message-ID: <154e089b0812141419y667e60b1mc662df886605ccd9@mail.gmail.com>
References: <49458560.0aa1660a.486c.7f09@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Karsten Keil" <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f12.google.com ([209.85.217.12]:59321 "EHLO
	mail-gx0-f12.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbYLNWTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 17:19:08 -0500
In-Reply-To: <49458560.0aa1660a.486c.7f09@mx.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ups. checkpatch.pl reports a couple of formatting errors, I'll fix
them and resubmit.

-Hannes

On Thu, Dec 11, 2008 at 4:07 PM, Hannes Eder <hannes@hanneseder.net> wrote:
> Fix this sparse warnings by making the functions static:
>
> drivers/isdn/hardware/eicon/di.c:356:6: warning: symbol 'isdn_rc' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/di.c:558:6: warning: symbol 'isdn_ind' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:595:6: warning: symbol 'api_parse' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:634:6: warning: symbol 'api_save_msg' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:666:6: warning: symbol 'api_load_msg' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:3417:6: warning: symbol 'manufacturer_req' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:3745:6: warning: symbol 'manufacturer_res' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:4077:6: warning: symbol 'control_rc' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:4743:6: warning: symbol 'data_rc' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:4779:6: warning: symbol 'data_ack' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:4805:6: warning: symbol 'sig_ind' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:6173:6: warning: symbol 'SendInfo' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:6349:6: warning: symbol 'SendMultiIE' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:6468:6: warning: symbol 'nl_ind' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:7250:6: warning: symbol 'get_plci' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:7409:6: warning: symbol 'add_d' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:7427:6: warning: symbol 'add_ai' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:7448:6: warning: symbol 'add_b1' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:7912:6: warning: symbol 'add_b23' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:8709:6: warning: symbol 'nl_req_ncci' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:8731:6: warning: symbol 'send_req' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:8866:6: warning: symbol 'listen_check' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:8909:6: warning: symbol 'IndParse' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:8994:6: warning: symbol 'ie_compare' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:9003:6: warning: symbol 'find_cip' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:9071:6: warning: symbol 'SetVoiceChannel' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:9089:6: warning: symbol 'VoiceChannelOff' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:9102:6: warning: symbol 'AdvCodecSupport' was not declared. Should it be static?
> drivers/isdn/hardware/eicon/message.c:9198:6: warning: symbol 'CodecIdCheck' was not declared. Should it be static?
>
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> ---
>  drivers/isdn/hardware/eicon/di.c      |   28 ++++++++--------
>  drivers/isdn/hardware/eicon/message.c |   54 ++++++++++++++++----------------
>  2 files changed, 41 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/isdn/hardware/eicon/di.c b/drivers/isdn/hardware/eicon/di.c
> index 10760b3..d798fb4 100644
> --- a/drivers/isdn/hardware/eicon/di.c
> +++ b/drivers/isdn/hardware/eicon/di.c
> @@ -353,13 +353,13 @@ void scom_clear_int(ADAPTER * a)
>  /*------------------------------------------------------------------*/
>  /* return code handler                                              */
>  /*------------------------------------------------------------------*/
> -byte isdn_rc(ADAPTER * a,
> -             byte Rc,
> -             byte Id,
> -             byte Ch,
> -             word Ref,
> -             dword extended_info_type,
> -             dword extended_info)
> +static byte isdn_rc(ADAPTER * a,
> +                    byte Rc,
> +                    byte Id,
> +                    byte Ch,
> +                    word Ref,
> +                    dword extended_info_type,
> +                    dword extended_info)
>  {
>   ENTITY  * this;
>   byte e_no;
> @@ -555,13 +555,13 @@ byte isdn_rc(ADAPTER * a,
>  /*------------------------------------------------------------------*/
>  /* indication handler                                               */
>  /*------------------------------------------------------------------*/
> -byte isdn_ind(ADAPTER * a,
> -              byte Ind,
> -              byte Id,
> -              byte Ch,
> -              PBUFFER * RBuffer,
> -              byte MInd,
> -              word MLength)
> +static byte isdn_ind(ADAPTER * a,
> +                     byte Ind,
> +                     byte Id,
> +                     byte Ch,
> +                     PBUFFER * RBuffer,
> +                     byte MInd,
> +                     word MLength)
>  {
>   ENTITY  * this;
>   word clength;
> diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
> index 599fed8..339e4ed 100644
> --- a/drivers/isdn/hardware/eicon/message.c
> +++ b/drivers/isdn/hardware/eicon/message.c
> @@ -592,7 +592,7 @@ word api_put(APPL   * appl, CAPI_MSG   * msg)
>  /* api_parse function, check the format of api messages             */
>  /*------------------------------------------------------------------*/
>
> -word api_parse(byte   * msg, word length, byte * format, API_PARSE * parms)
> +static word api_parse(byte   * msg, word length, byte * format, API_PARSE * parms)
>  {
>   word i;
>   word p;
> @@ -631,7 +631,7 @@ word api_parse(byte   * msg, word length, byte * format, API_PARSE * parms)
>   return false;
>  }
>
> -void api_save_msg(API_PARSE   *in, byte *format, API_SAVE   *out)
> +static void api_save_msg(API_PARSE   *in, byte *format, API_SAVE   *out)
>  {
>   word i, j, n = 0;
>   byte   *p;
> @@ -663,7 +663,7 @@ void api_save_msg(API_PARSE   *in, byte *format, API_SAVE   *out)
>   out->parms[i].length = 0;
>  }
>
> -void api_load_msg(API_SAVE   *in, API_PARSE   *out)
> +static void api_load_msg(API_SAVE   *in, API_PARSE   *out)
>  {
>   word i;
>
> @@ -3414,7 +3414,7 @@ byte select_b_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
>   return false;
>  }
>
> -byte manufacturer_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
> +static byte manufacturer_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
>  {
>   word command;
>   word i;
> @@ -3742,7 +3742,7 @@ byte manufacturer_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * p
>  }
>
>
> -byte manufacturer_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
> +static byte manufacturer_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
>  {
>   word indication;
>
> @@ -4074,7 +4074,7 @@ capi_callback_suffix:
>  }
>
>
> -void control_rc(PLCI   * plci, byte req, byte rc, byte ch, byte global_req, byte nl_rc)
> +static void control_rc(PLCI   * plci, byte req, byte rc, byte ch, byte global_req, byte nl_rc)
>  {
>   dword Id;
>   dword rId;
> @@ -4740,7 +4740,7 @@ void control_rc(PLCI   * plci, byte req, byte rc, byte ch, byte global_req, byte
>   }
>  }
>
> -void data_rc(PLCI   * plci, byte ch)
> +static void data_rc(PLCI   * plci, byte ch)
>  {
>   dword Id;
>   DIVA_CAPI_ADAPTER   * a;
> @@ -4776,7 +4776,7 @@ void data_rc(PLCI   * plci, byte ch)
>   }
>  }
>
> -void data_ack(PLCI   * plci, byte ch)
> +static void data_ack(PLCI   * plci, byte ch)
>  {
>   dword Id;
>   DIVA_CAPI_ADAPTER   * a;
> @@ -4802,7 +4802,7 @@ void data_ack(PLCI   * plci, byte ch)
>   }
>  }
>
> -void sig_ind(PLCI   * plci)
> +static void sig_ind(PLCI   * plci)
>  {
>   dword x_Id;
>   dword Id;
> @@ -6170,7 +6170,7 @@ static void SendSetupInfo(APPL   * appl, PLCI   * plci, dword Id, byte   * * par
>  }
>
>
> -void SendInfo(PLCI   * plci, dword Id, byte   * * parms, byte iesent)
> +static void SendInfo(PLCI   * plci, dword Id, byte   * * parms, byte iesent)
>  {
>   word i;
>   word j;
> @@ -6346,7 +6346,7 @@ void SendInfo(PLCI   * plci, dword Id, byte   * * parms, byte iesent)
>  }
>
>
> -byte SendMultiIE(PLCI   * plci, dword Id, byte   * * parms, byte ie_type, dword info_mask, byte setupParse)
> +static byte SendMultiIE(PLCI   * plci, dword Id, byte   * * parms, byte ie_type, dword info_mask, byte setupParse)
>  {
>   word i;
>   word j;
> @@ -6465,7 +6465,7 @@ static void SendSSExtInd(APPL   * appl, PLCI   * plci, dword Id, byte   * * parm
>     }
>  };
>
> -void nl_ind(PLCI   * plci)
> +static void nl_ind(PLCI   * plci)
>  {
>   byte ch;
>   word ncci;
> @@ -7247,7 +7247,7 @@ void nl_ind(PLCI   * plci)
>  /* find a free PLCI                                                 */
>  /*------------------------------------------------------------------*/
>
> -word get_plci(DIVA_CAPI_ADAPTER   * a)
> +static word get_plci(DIVA_CAPI_ADAPTER   * a)
>  {
>   word i,j;
>   PLCI   * plci;
> @@ -7406,7 +7406,7 @@ static void add_ie(PLCI   * plci, byte code, byte   * p, word p_length)
>  /* put a unstructured data into the buffer                          */
>  /*------------------------------------------------------------------*/
>
> -void add_d(PLCI   * plci, word length, byte   * p)
> +static void add_d(PLCI   * plci, word length, byte   * p)
>  {
>   word i;
>
> @@ -7424,7 +7424,7 @@ void add_d(PLCI   * plci, word length, byte   * p)
>  /* parameter buffer                                                 */
>  /*------------------------------------------------------------------*/
>
> -void add_ai(PLCI   * plci, API_PARSE * ai)
> +static void add_ai(PLCI   * plci, API_PARSE * ai)
>  {
>   word i;
>     API_PARSE ai_parms[5];
> @@ -7445,7 +7445,7 @@ void add_ai(PLCI   * plci, API_PARSE * ai)
>  /* put parameter for b1 protocol in the parameter buffer            */
>  /*------------------------------------------------------------------*/
>
> -word add_b1(PLCI   * plci, API_PARSE * bp, word b_channel_info, word b1_facilities)
> +static word add_b1(PLCI   * plci, API_PARSE * bp, word b_channel_info, word b1_facilities)
>  {
>     API_PARSE bp_parms[8];
>     API_PARSE mdm_cfg[9];
> @@ -7909,7 +7909,7 @@ word add_b1(PLCI   * plci, API_PARSE * bp, word b_channel_info, word b1_faciliti
>  /* put parameter for b2 and B3  protocol in the parameter buffer    */
>  /*------------------------------------------------------------------*/
>
> -word add_b23(PLCI   * plci, API_PARSE * bp)
> +static word add_b23(PLCI   * plci, API_PARSE * bp)
>  {
>   word i, fax_control_bits;
>   byte pos, len;
> @@ -8706,7 +8706,7 @@ void sig_req(PLCI   * plci, byte req, byte Id)
>  /* send a request for the network layer entity                      */
>  /*------------------------------------------------------------------*/
>
> -void nl_req_ncci(PLCI   * plci, byte req, byte ncci)
> +static void nl_req_ncci(PLCI   * plci, byte req, byte ncci)
>  {
>   if(!plci) return;
>   if(plci->adapter->adapter_disabled) return;
> @@ -8728,7 +8728,7 @@ void nl_req_ncci(PLCI   * plci, byte req, byte ncci)
>   plci->req_in_start = plci->req_in;
>  }
>
> -void send_req(PLCI   * plci)
> +static void send_req(PLCI   * plci)
>  {
>   ENTITY   * e;
>   word l;
> @@ -8863,7 +8863,7 @@ void send_data(PLCI   * plci)
>   }
>  }
>
> -void listen_check(DIVA_CAPI_ADAPTER   * a)
> +static void listen_check(DIVA_CAPI_ADAPTER   * a)
>  {
>   word i,j;
>   PLCI   * plci;
> @@ -8906,7 +8906,7 @@ void listen_check(DIVA_CAPI_ADAPTER   * a)
>  /* functions for all parameters sent in INDs                        */
>  /*------------------------------------------------------------------*/
>
> -void IndParse(PLCI   * plci, word * parms_id, byte   ** parms, byte multiIEsize)
> +static void IndParse(PLCI   * plci, word * parms_id, byte   ** parms, byte multiIEsize)
>  {
>   word ploc;            /* points to current location within packet */
>   byte w;
> @@ -8991,7 +8991,7 @@ void IndParse(PLCI   * plci, word * parms_id, byte   ** parms, byte multiIEsize)
>  /* try to match a cip from received BC and HLC                      */
>  /*------------------------------------------------------------------*/
>
> -byte ie_compare(byte   * ie1, byte * ie2)
> +static byte ie_compare(byte   * ie1, byte * ie2)
>  {
>   word i;
>   if(!ie1 || ! ie2) return false;
> @@ -9000,7 +9000,7 @@ byte ie_compare(byte   * ie1, byte * ie2)
>   return true;
>  }
>
> -word find_cip(DIVA_CAPI_ADAPTER   * a, byte   * bc, byte   * hlc)
> +static word find_cip(DIVA_CAPI_ADAPTER   * a, byte   * bc, byte   * hlc)
>  {
>   word i;
>   word j;
> @@ -9068,7 +9068,7 @@ static byte AddInfo(byte   **add_i,
>  /* voice and codec features                                         */
>  /*------------------------------------------------------------------*/
>
> -void SetVoiceChannel(PLCI   *plci, byte   *chi, DIVA_CAPI_ADAPTER   * a)
> +static void SetVoiceChannel(PLCI   *plci, byte   *chi, DIVA_CAPI_ADAPTER   * a)
>  {
>   byte voice_chi[] = "\x02\x18\x01";
>   byte channel;
> @@ -9086,7 +9086,7 @@ void SetVoiceChannel(PLCI   *plci, byte   *chi, DIVA_CAPI_ADAPTER   * a)
>   }
>  }
>
> -void VoiceChannelOff(PLCI   *plci)
> +static void VoiceChannelOff(PLCI   *plci)
>  {
>   dbug(1,dprintf("ExtDevOFF"));
>   add_p(plci,FTY,"\x02\x01\x08");             /* B Off */
> @@ -9099,7 +9099,7 @@ void VoiceChannelOff(PLCI   *plci)
>  }
>
>
> -word AdvCodecSupport(DIVA_CAPI_ADAPTER   *a, PLCI   *plci, APPL   *appl, byte hook_listen)
> +static word AdvCodecSupport(DIVA_CAPI_ADAPTER   *a, PLCI   *plci, APPL   *appl, byte hook_listen)
>  {
>   word j;
>   PLCI   *splci;
> @@ -9195,7 +9195,7 @@ word AdvCodecSupport(DIVA_CAPI_ADAPTER   *a, PLCI   *plci, APPL   *appl, byte ho
>  }
>
>
> -void CodecIdCheck(DIVA_CAPI_ADAPTER   *a, PLCI   *plci)
> +static void CodecIdCheck(DIVA_CAPI_ADAPTER   *a, PLCI   *plci)
>  {
>
>   dbug(1,dprintf("CodecIdCheck"));
> --
> 1.5.6.3
>
>
